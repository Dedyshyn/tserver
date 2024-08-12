insert into groups_server (server_id, name, type, org_group_id) select :server_id:, name, 1, group_id from groups_server where server_id=0 and type=0;
insert into groups_channel (server_id, name, type, org_group_id) select :server_id:, name, 1, group_id from groups_channel where server_id=0 and type=0;

insert into perm_server_group(server_id, id1, id2, perm_id, perm_value, perm_negated, perm_skip)
             select :server_id:, B.group_id, A.id2, A.perm_id, A.perm_value, A.perm_negated, A.perm_skip from perm_server_group A join groups_server B on A.id1=B.org_group_id where A.server_id=0 and B.server_id=:server_id:;
             
insert into perm_channel_groups(server_id, id1, id2, perm_id, perm_value, perm_negated, perm_skip)
             select :server_id:, B.group_id, A.id2, A.perm_id, A.perm_value, A.perm_negated, A.perm_skip from perm_channel_groups A join groups_channel B on A.id1=B.org_group_id where A.server_id=0 and B.server_id=:server_id:;

insert into tokens ( server_id, token_key, token_type, token_id1, token_id2, token_created, token_description, token_customset, token_from_client_id)
    select  :server_id:,  :token_key:,  0,  group_id,  0,  :token_created:,  'default serveradmin privilege key',  '',  NULL from groups_server where org_group_id=:serveradmin_group: and server_id=:server_id:;

delete from server_properties where id=:server_id: and ident in ('virtualserver_default_server_group','virtualserver_default_channel_group','virtualserver_default_channel_admin_group', 'virtualserver_autogenerated_privilegekey');
insert into server_properties ( server_id, id, ident, value) 
    select :server_id:, :server_id:, 'virtualserver_default_server_group', cast(group_id as CHAR(50)) from groups_server where org_group_id=:serverdefault_group: and server_id=:server_id: union 
    select :server_id:, :server_id:, 'virtualserver_default_channel_group', cast(group_id as CHAR(50)) from groups_channel where org_group_id=:channeldefault_group: and server_id=:server_id: union 
    select :server_id:, :server_id:, 'virtualserver_default_channel_admin_group', cast(group_id AS CHAR(50)) from groups_channel where org_group_id=:channeladmin_group: and server_id=:server_id: union
    select :server_id:, :server_id:, 'virtualserver_autogenerated_privilegekey', :token_key:;