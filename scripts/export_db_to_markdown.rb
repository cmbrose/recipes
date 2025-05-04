#!/usr/bin/env ruby
# frozen_string_literal: true

require "active_record"
require "yaml"
require "json"
require "fileutils"

# ---------- 1. DB connection ----------
ActiveRecord::Base.establish_connection(
  adapter:  "mysql2",
  host:     ENV.fetch("DB_HOST", "127.0.0.1"),
  port:     ENV.fetch("DB_PORT", 3306),
  database: ENV.fetch("DB_NAME", "recipes"),
  username: ENV.fetch("DB_USER", "recipes"),
  password: ENV.fetch("DB_PASS", ""),
  sslca: "/workspaces/recipes/db_ssl/DigiCertGlobalRootCA.crt.pem", 
  ssl_mode: "REQUIRED"
)

class Recipe < ActiveRecord::Base
  self.table_name = "recipes"
end

# ---------- 2. helpers ----------
def slug(str)
  str.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
end

def parse_array(txt)
  return [] if txt.nil? || txt.strip.empty?
  JSON.parse(txt)
rescue JSON::ParserError
  txt.split(/[\n;]+/).map(&:strip).reject(&:empty?)
end

# ---------- 3. export loop ----------
out_dir = "_recipes"
FileUtils.mkdir_p(out_dir)

Recipe.find_each(batch_size: 100) do |r|
  front = {
    title:       r.name,
    name:        r.name,
    prep_time:   r.prep_time,
    cook_time:   r.cook_time,
    total_time:  r.total_time,
    servings:    r.servings,
    tags:        parse_array(r.tags),
    preview_url: r.preview_url,
    source:      r.source,
    source_kind: r.source_kind,
    notes:       parse_array(r.notes)
  }.compact

  ingredients = parse_array(r.ingredients)
  steps       = parse_array(r.directions)

  File.open(File.join(out_dir, "#{slug(r.name || "recipe-#{r.id}")}.md"), "w") do |f|
    f.puts front.to_yaml
    f.puts "---"
    f.puts
    f.puts "## Ingredients"
    ingredients.each { |item| 
        f.puts "### #{item["name"]}" if item["name"].present?
        item["ingredients"].each { |i| f.puts "- #{i}" }
        f.puts
    }
    f.puts
    f.puts "## Directions"
    steps.each_with_index { |step, i| f.puts "#{i + 1}. #{step}" }
  end
end

puts "✓ Export complete — files in #{out_dir}/"