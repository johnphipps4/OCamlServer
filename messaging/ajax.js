var xhr = new XMLHttpRequest(),
    method = "GET",
    url = "https://developer.mozilla.org/"; //this would be our server domain

xhr.open(method, url, true);
xhr.onreadystatechange = function () {
  if(xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
    console.log(xhr.responseText);
  }
};
xhr.send();