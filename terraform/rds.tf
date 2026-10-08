# Base PostgreSQL RDS dans les sous-réseaux privés (exercice 2)

resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-db-subnets"
  description = "Sous-reseaux prives de la base MediTrack"
  subnet_ids  = aws_subnet.private[*].id

  tags = { Name = "${var.project}-db-subnets" }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project}-db"
  engine         = "postgres"
  engine_version = "18"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username

  # Mot de passe généré par RDS et stocké dans Secrets Manager
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Le plan gratuit du compte limite la rétention des sauvegardes à 1 jour
  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  # Réglages de TP. En production : multi_az, deletion_protection et snapshot final.
  multi_az            = false
  deletion_protection = false
  skip_final_snapshot = true
  apply_immediately   = true

  tags = { Name = "${var.project}-db" }
}
