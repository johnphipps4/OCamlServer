README

Make sure you have the following packages (opam install):

	- cohttp
	- cohttp-lwt-unix
	- nocrypto
	- yojson


To compile: "make compile" - this adds bot people to the user file.

For local host: "php -S localhost:8000"

Open your browser (Please use google Chrome - CSS works in Chrome & sometimes fails in other browsers) and type in "localhost:8000".

The first page you will see is index.html. Here you can make an account or log in.

Signup will redirect you to a page where you can select courses you've taken and give them ratings. Please give ratings from 1 to 5, and select at least one box per section.

Submitting will redirect to the recommendations page. Clicking the buttons on the left sidebar will output the set of users that are similar to you via that specific metric "similar likes, similar dislikes etc..."

On the left sidebar is a link to the messaging feature. This allows you to type in the netid of another user and have a conversation with them over http via ocaml code.

Thanks!!

