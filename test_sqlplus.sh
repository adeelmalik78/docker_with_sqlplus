cat > test_connect.sql << 'EOF' 
connect ADEEL/"ADEEL#MALIK"@cs-oracledb.liquibase.net:1521/PP_DEV
show user 
exit 
EOF
sqlplus /nolog @test_connect.sql 
