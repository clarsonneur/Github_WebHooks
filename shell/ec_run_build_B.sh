#!/usr/bin/env bash
ectool --server 192.168.1.1 login 'admin' 'changeme'
ectool runProcedure 'GitHub_Webhooks' --procedureName 'build_branch_A'
