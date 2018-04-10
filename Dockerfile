FROM perl:5

MAINTAINER clarsonneur@free.fr

RUN cpan install Plack && \
    cpan install JSON && \
    cpan install String::Compare::ConstantTime

COPY ef_gwh_listener/ /src/ef_gwh_listener/
COPY shell/ /src/shell
COPY entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT /tmp/entrypoint.sh
