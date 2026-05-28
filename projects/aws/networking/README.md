# AWS Networking — Week 4

Concepts studied and infrastructure built during Week 4 of the Cloud Engineering Programme.

## Concepts Covered

### VPC (Virtual Private Cloud)
- Isolated private network in AWS where your resources live
- Default VPC CIDR: `172.31.0.0/16` — auto-created by AWS in every region
- Custom VPC CIDR: `10.0.0.0/16` — standard choice for production environments

### Subnets
- Subdivisions of a VPC, scoped to a single Availability Zone
- **/24 subnet** = 256 addresses, 251 usable (AWS reserves 5 per subnet)
- **Public subnet** — route table contains `0.0.0.0/0 → IGW`
- **Private subnet** — no `0.0.0.0/0` route, no direct internet access

### AWS Reserved IPs (per subnet)
| Address | Purpose |
|---|---|
| x.x.x.0 | Network address |
| x.x.x.1 | VPC Router |
| x.x.x.2 | AWS DNS Resolver |
| x.x.x.3 | Reserved for future AWS use |
| x.x.x.255 | Broadcast address |

### Internet Gateway (IGW)
- One per VPC — the bridge between the VPC and the public internet
- Must be attached to the VPC and referenced in a route table to be active

### Route Tables
- Rules that tell traffic where to go
- `0.0.0.0/0 → IGW` = public subnet (all traffic goes to internet gateway)
- Each subnet must be associated with exactly one route table

### Security Groups vs NACLs

| Feature | Security Group | NACL |
|---|---|---|
| Level | Instance | Subnet |
| Stateful/Stateless | Stateful | Stateless |
| Rule types | Allow only | Allow + Deny |
| Rule evaluation | All rules evaluated | Rules evaluated in number order |
| Default inbound | Blocked | Allowed (default NACL) |

### Stateful vs Stateless
- **Stateful (SG):** Return traffic for allowed connections is automatically permitted — no extra rule needed
- **Stateless (NACL):** Every direction evaluated independently — must write both inbound AND outbound rules

### Ephemeral Ports
- Range: `1024–65535`
- When a client receives a response, it arrives on a randomly assigned high port
- NACLs must explicitly allow outbound `1024–65535` or response traffic is dropped
- Security Groups are unaffected (stateful)

### NAT Gateway
- Allows resources in **private subnets** to reach the internet (e.g. for updates)
- Outbound only — internet cannot initiate connections back in

---

## Infrastructure Built — legend-vpc

Custom VPC built from scratch in `us-east-1`.

| Component | Value |
|---|---|
| VPC Name | legend-vpc |
| VPC CIDR | `10.0.0.0/16` |
| Public Subnet | `10.0.1.0/24` — us-east-1a |
| Internet Gateway | legend-igw |
| Route Table | legend-public-rt (`0.0.0.0/0 → legend-igw`) |
| Security Group | legend-web-sg (inbound: 80, 443 / outbound: all) |
| Test EC2 | legend-vpc-test (stopped) |

### What This Demonstrates
- Designed and deployed a custom VPC with full internet connectivity
- Configured public routing via Internet Gateway and Route Table
- Applied Security Group rules to control traffic at the instance level
- Understood the difference between default and custom VPC architecture

---

*Part of the Cloud Engineering Portfolio — github.com/legendonthisone/cloud-engineering-portfolio*
