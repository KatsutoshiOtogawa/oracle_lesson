cat << END >> ~/.bash_profile
function enable_rails () {
    dnf -y install rubygem-rails sqlite-devel libsass node yarnpkg 
    yarn global add webpack

    # enable rails default development port
    firewall-cmd --add-port=3000/tcp --zone=public --permanent
    firewall-cmd reload

    sqlplus system/\$ORACLE_PASSWORD@XEPDB1 << EOF
    CREATE TABLESPACE testdevtbs
    DATAFILE '/opt/oracle/oradata/XE/XEPDB1/testdevtbs001.dbf' 
    SIZE 1G
    ;
EOF

    sqlplus system/\$ORACLE_PASSWORD@XEPDB1 << EOF
    CREATE TABLESPACE testdevtmptbs
    DATAFILE '/opt/oracle/oradata/XE/XEPDB1/testdevtmptbs001.dbf' 
    SIZE 1G
    ;
EOF
    # create rails dev
    # see [CREATE SESSION PRIVIREDS](http://nkurilog.blogspot.com/2018/02/oracle-connectresource.html)
    # Don't use user name underscore symbol. underscore 
    sqlplus system/\$ORACLE_PASSWORD@XEPDB1 << EOF
    CREATE USER railsdev IDENTIFIED BY railsdev
    DEFAULT TABLESPACE
        testdevtbs
    TEMPORARY TABLESPACE
        TEMP
    PROFILE
        DEFAULT
    ;
    -- testdevtmptbs
    GRANT CREATE SESSION,CREATE TABLE,CREATE SEQUENCE to railsdev;
    ALTER USER railsdev ACCOUNT UNLOCK;
    ALTER USER railsdev QUOTA 10M ON testdevtbs;
EOF
    sqlplus system/\$ORACLE_PASSWORD@XEPDB1 << EOF
    CREATE USER railstest IDENTIFIED BY railstest
    DEFAULT TABLESPACE
        USERS
    TEMPORARY TABLESPACE
        TEMP
    PROFILE
        DEFAULT
    ;
    GRANT CREATE SESSION,CREATE TABLE,CREATE SEQUENCE to railstest;
EOF
    sqlplus system/\$ORACLE_PASSWORD@XEPDB1 << EOF
    CREATE USER railsprod IDENTIFIED BY railsprod
    DEFAULT TABLESPACE
        USERS
    TEMPORARY TABLESPACE
        TEMP
    PROFILE
        DEFAULT
    ;
    GRANT CREATE SESSION,CREATE TABLE,CREATE SEQUENCE to railsprod;
EOF

    # enable oracle database client library for using rails.
    # need to build oci8
    set -eux
    export LD_LIBRARY_PATH=\$ORACLE_HOME/lib
    gem install ruby-oci8
}

# DROP USER railsdev CASCADE;

function enable_django () {
    dnf -y install python3-django

    # enable django default development port
    firewall-cmd --add-port=8000/tcp --zone=public --permanent
    firewall-cmd reload
}

function enable_dotnetcore () {
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    curl -o /etc/yum.repos.d/microsoft-prod.repo -L https://packages.microsoft.com/config/fedora/33/prod.repo
    dnf -y install dotnet-sdk-5.0
}

function enable_koajs () {
    dnf -y install yarnpkg
    yarn global add koa
}

function enable_django_secretkey () {
    python3 << EOF
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
EOF
}

END
