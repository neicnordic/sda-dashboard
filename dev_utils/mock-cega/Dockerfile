FROM golang:1.19-alpine
WORKDIR /source

COPY ./mock-cega/go.mod ./
COPY ./mock-cega/go.sum ./

RUN go mod download

COPY ./mock-cega/mockcega.go ./
COPY ./mock-cega/schemas /schemas

RUN CGO_ENABLED=0 go build -o /bin/mock-cega

CMD [ "/bin/mock-cega" ]
