# cloudforms-heat-deployment

This project aims to deploy a minimal production like Red Hat Cloudforms cluster in an OpenStack project using HEAT and Ansible (managed by heat).

# Highlights

 - Creates the cloudforms project (tenant) on an Keystone V3 network domain
 - Set quotas on Compute, Network and Storage
 - Create appliance image hardware profiles for the cluster as per documentation specification
 - Create a core cluster router with 4 segregated networks ( Bastion, Database, Portal, Worker )
 - Deploy a HTTP/HTTPS load balancer for the web portals using Octavia
 - Implement restricted ingress access to the different networks/nodes via Security groups
 - Deploy instances with predictable internal IP addresses
 - Assign floating IP addresses
 - Create and attach 1 or more external volumes for database, logging and temp space
 - Create and assign anti-affinity policies to nodes to enhance HA
 - Configure Neutron RBAC to allow the worker nodes access to the undercloud network so the director can be enrolled.
 - Instances are enrolled against a local Satellite 6.5 server
 - Nodes are joined to the IDM domain with a dynamic dns update using the assigned floating IP.
 - The Cloudforms appliance nodes are configured by ansible invoked by Heat.
 
## The deployment
 - 1 Bastion Host
 - 2 Database Nodes (Active/Passive DB replication with auto failover)
 - 2 Web Portals (Fronted by an Octavia Loadbalancer)
 - 3 Workers (Access to the Undercloud for Director Infra Enrollment and 1TB temp space to facilitate guest smart state analysis)
