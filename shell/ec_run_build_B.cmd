REM Test script to start "Build branch A"

@echo "Login to EC server..."

call ectool --server 192.168.1.1 login "admin" "changeme"

@echo "Starting Build branch A..."

call ectool runProcedure "GitHub_Webhooks" --procedureName "build_branch_B"

REM exit