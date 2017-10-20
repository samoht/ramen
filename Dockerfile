FROM ocaml/opam:alpine as build

ADD ramen.opam /src/
RUN opam pin add ramen.dev /src -n
RUN opam depext -yu ramen
RUN opam install ramen --deps -t

ADD . /src/
RUN opam update ramen
RUN opam install ramen -tv
RUN sudo cp /home/opam/.opam/4.04.2/bin/ramen /usr/local/bin

FROM alpine

COPY --from=build /usr/local/bin/ramen /usr/local/bin

WORKDIR /data
ENTRYPOINT ["/usr/local/bin/ramen"]
