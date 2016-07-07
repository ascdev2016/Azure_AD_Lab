@{ 
    AllNodes = @( 
        @{ 
            Nodename = 'localhost'
            PSDscAllowDomainUser = $true
        }
    )

    NonNodeData = @{

        UserData = @'
UserName,Password,Department,sn
svc_sp_farm,P@ssw0rd,SharePoint,SharePoint Farm Account
svc_sp_search,P@ssw0rd,SharePoint,SharePoint Search Account
svc_sp_crawl,P@ssw0rd,SharePoint,SharePoint Crawl Account
svc_sp_apppool,P@ssw0rd,SharePoint,SharePoint AppPool Account
svc_sp_suser,P@ssw0rd,SharePoint,SharePoint Super User Account
svc_sp_sreader,P@ssw0rd,SharePoint,SharePoint Super Reader Account
svc_sp_mysite,P@ssw0rd,SharePoint,SharePoint MySite Account
svc_sql_admin,P@ssw0rd,SQL,SQL Admin Account
svc_sql_engine,P@ssw0rd,SQL,SQL Engine Account
'@

        RootOUs = 'SharePoint','SQL'
        ChildOUs = 'Users','Computers','Groups'
        TestObjCount = 5

    }
} 
