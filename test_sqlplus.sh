cat > test_connect.sql << 'EOF' 
connect username/"adeel#malik"@connection_string
show user 
exit 
EOF
sqlplus /nolog @test_connect.sql 
