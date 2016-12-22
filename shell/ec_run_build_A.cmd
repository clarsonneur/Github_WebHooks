REM Test script to start "Build branch A"

@echo "Login to EC server..."

call ectool --server 192.168.2.83 login "admin" "changeme"

@echo "Starting Build branch A..."

call ectool runProcedure "GitHub_Webhooks" --procedureName "build_branch_A"

REM exit