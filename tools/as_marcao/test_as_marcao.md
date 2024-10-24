```mermaid
---
title: Testing process for as_marcao plugin
---
sequenceDiagram;
actor HM
actor Lyrasis
actor Princeton
participant aspace-staging 
participant aspace-prod
participant sftp-staging1
participant sftp-prod1
participant Alma-Sandbox
participant Alma-prod

HM-->>Princeton:releases as_marcao v0.1
Lyrasis-->>aspace-staging: installs as_marcao v.0.1
aspace-staging->>aspace-staging:fails
HM-->>Princeton: releases user_defined_in_basic v.1.0: fixes as_marcao dependency
Lyrasis-->>aspace-staging: installs user_defined_in_basic v.1.0
aspace-staging-->>sftp-staging1:runs as_marcao v0.1
sftp-staging1->>sftp-staging1: fails
Princeton-->>sftp-staging1: updates sftp-staging1 write permissions
sftp-staging1->>sftp-staging1: fails
Princeton-->>sftp-staging1: updates sftp-staging1 firewall rules
sftp-staging1->>sftp-staging1: fails
Princeton-->>sftp-staging1: updates sftp-staging1 authentication timeout
sftp-staging1->>sftp-staging1: fails
HM-->>Princeton:releases as_marcao v0.2: adds config option for SFTP timeout
Lyrasis-->>aspace-staging: installs as_marcao v.0.2
aspace-staging-->>sftp-staging1:runs as_marcao v0.2
sftp-staging1->>sftp-staging1: fails
HM-->>Princeton:releases as_marcao v0.3: swaps net/sftp gem for java implementation
Lyrasis-->>aspace-staging: installs as_marcao v.0.3
aspace-staging-->>sftp-staging1:runs as_marcao v0.3
sftp-staging1->>sftp-staging1: fails
Princeton-->>sftp-staging1: updates user
aspace-staging-->>sftp-staging1:runs as_marcao v0.3
sftp-staging1->>sftp-staging1: SUCCEEDS
HM-->>Princeton:releases as_marcao v0.4: tweaks incremental export logic
HM-->>Princeton:releases as_marcao v0.5: tweaks report
Lyrasis-->>aspace-staging: installs as_marcao v.0.5
aspace-staging-->>sftp-staging1:runs as_marcao v0.5
sftp-staging1->>sftp-staging1: SUCCEEDS
Princeton-->>sftp-prod1: migrates server
Lyrasis-->>aspace-staging: removes as_marcao v.0.5
Lyrasis-->>aspace-prod: installs as_marcao v.0.5
Princeton-->>sftp-staging1: updates firewall rules for aspace-prod
aspace-prod-->>sftp-staging1:runs as_marcao v0.5
sftp-staging1->>sftp-staging1: fails
Lyrasis-->>aspace-prod: adds config
aspace-prod-->>sftp-staging1:runs as_marcao v0.5
sftp-staging1->>sftp-staging1: SUCCEEDS
aspace-prod-->>sftp-prod1:runs as_marcao v0.5
sftp-prod1->>sftp-prod1:SUCCEEDS
sftp-prod1-->>Alma-Sandbox:manual import
Alma-Sandbox->>Alma-Sandbox:SUCCEEDS
sftp-prod1-->>Alma-prod:scheduled import
Alma-prod->>Alma-prod:SUCCEEDS
```
