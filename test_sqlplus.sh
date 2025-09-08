cat > test_connect.sql << 'EOF' 
connect adeel/"adeel#malik"@connection_string
show user 
exit 
EOF
sqlplus /nolog @test_connect.sql 
