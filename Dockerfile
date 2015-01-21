# Gerrit
#
# VERSION 0.2
FROM ubuntu:14.04
MAINTAINER JJ Geewax <jj@geewax.org>



# Gerrit environment variables.
ENV GERRIT_USER gerrit
ENV GERRIT_HOME /home/gerrit
ENV GERRIT_ROOT $GERRIT_HOME/gerrit
ENV GERRIT_WAR $GERRIT_HOME/gerrit.war

# Supervisor environment variables.
ENV SUPERVISOR_LOG_DIR /var/log/supervisor
ENV DEBIAN_FRONTEND noninteractive

# Deal with packages and modules.
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
openjdk-7-jre \
supervisor \
git \
vim


# Create users and directories
RUN useradd -m $GERRIT_USER \
&& mkdir -p $GERRIT_ROOT \
&& mkdir -p $SUPERVISOR_LOG_DIR


# Configure supervisor.
ADD ./supervisord.conf /etc/supervisor/conf.d/gerrit.conf

# Pull down the gerrit package.
ADD http://gerrit-releases.storage.googleapis.com/gerrit-2.9.3.war $GERRIT_WAR

# Make sure gerrit owns all of his stuff.
RUN chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Configure gerrit (as gerrit).
USER gerrit
RUN java -jar $GERRIT_WAR init --batch -d $GERRIT_ROOT --no-auto-start

# Add the config file overtop of whatever is generated (and fix ownership).
ADD gerrit $GERRIT_ROOT/
&& chown -R ${GERRIT_USER}:${GERRIT_USER} $GERRIT_HOME

# Jump back to root.
USER root

# Expose ports and start everything.
EXPOSE 80 29418 8080
CMD ["/usr/sbin/service", "supervisor", "start"]