/* Track & bubble up recently viewed recipes  — public domain */
(() => {
    const KEY = 'recent_recipes_v1';
    const LIMIT = 20;              // keep last 20 visits

    // ---------- helper: info about current page ----------
    const slug = document.body.dataset.recipeSlug;
    const title = document.body.dataset.recipeTitle;
    if (slug && title) {           // we're on a recipe page
        const list = JSON.parse(localStorage.getItem(KEY) || '[]')
            .filter(e => e.slug !== slug);
        list.unshift({ slug, title, ts: Date.now() });
        localStorage.setItem(KEY, JSON.stringify(list.slice(0, LIMIT)));
    }

    // ---------- on index: reorder list ----------
    const ul = document.getElementById('recipe-index');
    if (ul) {
        const recent = JSON.parse(localStorage.getItem(KEY) || '[]');
        if (!recent.length) return;

        const map = new Map(recent.map(e => [e.slug, e.ts]));
        [...ul.children]
            .filter(li => map.has(li.querySelector('a').getAttribute('href')))
            .sort((a, b) =>
                map.get(b.querySelector('a').href) - map.get(a.querySelector('a').href))
            .forEach(li => ul.prepend(li));
    }
})();