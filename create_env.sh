#!/bin/sh

#  create_env.sh
#  
#
#  Created by John Trujillo on 11/26/17.
#

opam install -y lwt cohttp cohttp-lwt cohttp-lwt-unix ssl tls

ocamlbuild new.native


ocamlc -c parser.mli
#ocamlc -c parser.mli

ocamlc -c users.mli
#ocamlc -c users.ml


echo "now run 'make' to see if everything was properly compiled"

