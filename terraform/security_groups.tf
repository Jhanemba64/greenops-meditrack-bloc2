# Groupes de sécurité : Internet -> ALB (80) -> tâches ECS (3000) -> RDS (5432).
# Les règles référencent des groupes plutôt que des IP, qui changent à chaque redémarrage des tâches.
# AWS refuse les apostrophes et les accents dans les descriptions.

resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "Load Balancer public - HTTP 80 depuis Internet"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project}-alb-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP depuis Internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Vers les conteneurs API uniquement"
  ip_protocol                  = "tcp"
  from_port                    = var.api_port
  to_port                      = var.api_port
  referenced_security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group" "ecs" {
  name        = "${var.project}-ecs-sg"
  description = "Conteneurs API - port 3000 depuis le Load Balancer uniquement"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project}-ecs-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "API depuis le Load Balancer uniquement"
  ip_protocol                  = "tcp"
  from_port                    = var.api_port
  to_port                      = var.api_port
  referenced_security_group_id = aws_security_group.alb.id
}

# 443 sortant via la NAT : ECR, Secrets Manager, CloudWatch Logs
resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs.id
  description       = "HTTPS sortant - ECR, Secrets Manager, CloudWatch Logs"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "Vers la base PostgreSQL uniquement"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.rds.id
}

# Pas de règle de sortie pour la base
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg"
  description = "Base PostgreSQL - port 5432 depuis les conteneurs API uniquement"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "${var.project}-rds-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  description                  = "PostgreSQL depuis les conteneurs API uniquement"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.ecs.id
}
