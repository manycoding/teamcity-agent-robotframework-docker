#!/bin/bash
if [ -z "$TEAMCITY_SERVER" ]; then
    echo "TEAMCITY_SERVER variable is not set, launch with -e TEAMCITY_SERVER=http://mybuildserver"
    exit 1
fi

if [ ! -d "$AGENT_DIR/bin" ]; then
    echo "$AGENT_DIR doesn't exist, pulling build-agent from $TEAMCITY_SERVER/update/buildAgent.zip";
    let waiting=0
    until curl -s -f -I -X GET $TEAMCITY_SERVER/update/buildAgent.zip; do
        let waiting+=3
        sleep 3
        if [ $waiting -eq 120 ]; then
            echo "Teamcity server did not respond within 120 seconds..."
            exit 42
        fi
    done
    wget $TEAMCITY_SERVER/update/buildAgent.zip && unzip -d $AGENT_DIR buildAgent.zip && rm buildAgent.zip
    chmod +x $AGENT_DIR/bin/agent.sh
    echo -e "serverUrl=$TEAMCITY_SERVER\nname=$AGENT_NAME\nteamcity.magic.authorizationToken='kla^Q59hznR8AvT$ziY!Co3wVbH6mQqnfF9ywrnAP5$w&Rkkz@'" > $AGENT_DIR/conf/buildAgent.properties
fi

git config --global http.sslVerify false

echo "Starting build agent..."
chown -R teamcity:teamcity /opt/buildAgent

wrapdocker gosu teamcity /opt/buildAgent/bin/agent.sh run