/*
 * Automatically generates a table of contents out of heading
 * elements on the page.
 */

function constructList(root, list) {
	for (const item of list) {
		let newNode = document.createElement("li");
		newNode.innerHTML = item.content;

		if (item.children.length > 0) {
			let sublist = document.createElement("ol");
			constructList(sublist, item.children);
			newNode.appendChild(sublist);
		}
		root.appendChild(newNode);
	}
}

document.addEventListener("DOMContentLoaded", (e) => {
	let headings = document.querySelectorAll("h1,h2,h3,h4,h5,h6");
	let toc = document.querySelector("div#toc");
	let items = [];
	let rootDepth;

	for (let i=1; i < headings.length; ++i) {
		if (headings[i].classList.contains("toc-exclude")) continue;

		if (headings[i].id === "") {
			headings[i].id = Number(((Math.floor(Math.random() * 0x10000) << 16) | (Date.now() & 0xFFFF)) >>> 0).toString(16);
		}

		let htmlContent;

		if (!headings[i].classList.contains("toc-nolink")) {
			htmlContent = `<a href="#${headings[i].id}"">${headings[i].innerHTML}</a>`;
		} else {
			htmlContent = headings[i].innerHTML;
		}

		if (items.length === 0) {
			items.push({content: htmlContent, children: []});
			rootDepth = Number(headings[i].tagName.slice(-1));
			continue;
		}

		let depth = Number(headings[i].tagName.slice(-1)) - rootDepth;
		let parent;

		if (depth == 0) {
			parent = items;
		} else {
			parent = items.slice(-1)[0].children;
		}

		while (depth > 1) {
			if (parent.length === 0) break;

			parent = parent.slice(-1)[0].children;
			--depth;
		}

		parent.push({content: htmlContent, children: []});
	}

	let heading = document.createElement("h2");
	heading.innerHTML = "Table of Contents";

	let root = document.createElement("ol");
	
	constructList(root, items);

	if (!toc.classList.contains("toc-no-heading")) toc.append(heading);
	toc.appendChild(root);
});
