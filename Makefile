lol:
	ocamlbuild -use-ocamlfind -pkg cohttp-lwt-unix -pkg yojson gserver.byte && ./gserver.byte

msg:
	ocamlbuild -use-ocamlfind -pkg yojson messages.byte && ./messages.byte

compile:
	ocamlbuild -use-ocamlfind -pkg yojson -pkg nocrypto gserver.cmo
	ocamlbuild -use-ocamlfind -pkg cohttp-lwt-unix -pkg nocrypto parser.cmo
	ocamlbuild -use-ocamlfind -pkg nocrypto users.cmo
	ocamlbuild -use-ocamlfind -pkg cohttp-lwt-unix -pkg nocrypto bot.byte && ./bot.byte likes jpt86@cornell.edu
	

test:
	ocamlbuild -use-ocamlfind -pkg oUnit -pkg yojson finalproject_test.byte && ./finalproject_test.byte

# check:
# 	bash checkenv.sh && bash checktypes.sh

zip:
	zip finalproject.zip *.ml* *.json

# zipcheck:
# 	bash checkzip.sh

clean:
	ocamlbuild -clean
	rm -f finalproject.zip
