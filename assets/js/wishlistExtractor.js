//https://www.bililite.com/blog/2016/04/05/again-to-an-amazon-wishlist-widget/
//TODO: test functionality on real wishlist id on US and DE site
async function wishlist(id) {
	const size = 100;
	const ret = [];
	const wishlistdom = new DOMParser().parseFromString('', 'text/html');
	
	// ignore parsing warnings
	const response = await fetch(`http://www.amazon.com/gp/registry/wishlist/${id}?disableNav=1`);
	const text = response.text();
	const div = wishlistdom.createElement('div');
	div.innerHTML = text;
	wishlistdom.body.appendChild(div);
	
	const xPathQuery = "//div[starts-with(@id,'item_')]";
	const items = wishlistdom.evaluate(xPathQuery, wishlistdom, null, XPathResult.ANY_TYPE, null);
	
	let item = items.iterateNext();
	while (item) {
	  const values = [];
	  const nodes = item.childNodes;
	  for (let i = 0; i < nodes.length; i++) {
		const value = nodes[i];
		if (value.textContent) values.push(value.textContent);
	  }
	  ret.push(values);
	  item = items.iterateNext();
	}

	for (let i = 0; i < items.length; i++) {
		pullDataFromItem(item[i]);
	}
  }

function pullDataFromItem(item) {
	//TODO: add 'date added', 'price'
	let JSONObject = {};
	JSONObject.variables = {};
	let xPathItemName = ".//a[starts-with(@id, 'itemName')]";
	link = document.evaluate(xPathItemName, item, null, XPathResult.ANY_TYPE, XPathResult.STRING_TYPE);
	href = link.attributes.getNamedItem('href').nodeValue;
	JSONObject.variables.link = href;
	title = link.textContent;
	JSONObject.variables.title = title;
	author = link.parentNode.nextSibling.textContent;
	JSONObject.variables.author = author;
	image = wishlistxpath.query(".//img", item).item(0).attributes.getNamedItem('src').nodeValue;
	JSONObject.variables.image = image;
}