macOS Installation 
   brew tap hashicorp/tap
   brew install hashicorp/tap/consul
   brew upgrade hashicorp/tap/consul
   consul agent -dev #to start the dev agent
   http://localhost:8500/ui  #consul ui
   stop the consul dev agent to move back to the original consul # it removes all the previous data
   node-name is hostname
   #To join client to cluster
     1. Have the consul server running on linux vm
     2. Create one more vm have consul installed and make it client wiht the following steps:

   If installed consul in linux host, add firewall rule to allow the laptop ip at port 8500
#Others Commands

 1004  netstat | grep consul
 1005  netstat | grep consul
 1006  netstat
 1007  clear
 1008  ls 
 1009  consul members
 1010  consul members
 1011  consul members -detailed
 1012  curl localhost:8500/v1/catalog/nodes
