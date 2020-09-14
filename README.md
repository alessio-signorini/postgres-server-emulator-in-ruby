# Postgres Server Emulator written in Ruby
This proof of concept demonstrates that is possible to build a Postgres
server emulator (with SSL support!) just using Ruby. It currently accepts
any query but does not responds to them. Implementing it is trivial but I
did not do it yet (reason is in the Motivation).

### Usage
Just run
```bash
./pgserver.rb
```
and it will start the fake Postgres server ready to responds on port 15432. It
will accept any username/password. To create the required `cert.pem` and
`key.pem` use
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

### Motivation
I started building this server because I wanted to connect our
[Confluence pages](https://www.atlassian.com/software/confluence)
to [AWS Kendra](https://aws.amazon.com/kendra/) so it could be indexed directly
without having to copy the content into an RDS instance. Turns out, Kendra
checks for the SSL certificate of the server and if it's not from Amazon it
simply errors out.

Nevertheless, this was a fun and useful experience.

### Protocol
The protocol used by Postgres is not complicated and described [in details on
their website](https://www.postgresql.org/docs/12/protocol.html). Messages are
generally simple, with a type identifier, the message length, and some more
data. The format of each type of message is also [exhaustively described on
Postgres' website](https://www.postgresql.org/docs/12/protocol-message-formats.html).
