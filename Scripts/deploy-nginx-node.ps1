param(
    [string]$Region = "us-east-1",
    [switch]$DryRun
)

# Parámetros principales del despliegue
$AmiId           = "ami-0acc26f2c3cb45e96"   # AMI nginx-node-base con Nginx y Node.js
$InstanceType    = "t2.micro"                # Free Tier
$KeyName         = "packer-nginx"
$SecurityGroupId = "sg-02f053e55e9b0a368"
$SubnetId        = "subnet-079d6ae95553d5502"
$TagName         = "nginx-node-auto"

# Construcción de los argumentos para AWS CLI
$runArgs = @(
    "ec2","run-instances",
    "--image-id", $AmiId,
    "--instance-type", $InstanceType,
    "--key-name", $KeyName,
    "--security-group-ids", $SecurityGroupId,
    "--subnet-id", $SubnetId,
    "--associate-public-ip-address",
    "--tag-specifications", "ResourceType=instance,Tags=[{Key=Name,Value=$TagName}]"
)

if ($DryRun) {
    $runArgs += "--dry-run"
}

# Comando de despliegue automatizado usando el perfil 'default'
$runResult  = aws @runArgs --region $Region | ConvertFrom-Json
$InstanceId = $runResult.Instances[0].InstanceId

# Esperar a que la instancia pase los health checks
aws ec2 wait instance-status-ok `
  --instance-ids $InstanceId `
  --region $Region

# Obtener la IP pública asignada
$PublicIp = aws ec2 describe-instances `
  --instance-ids $InstanceId `
  --query "Reservations[0].Instances[0].PublicIpAddress" `
  --output text `
  --region $Region

# Verificar que Nginx responde correctamente
$response = Invoke-WebRequest -Uri ("http://" + $PublicIp) -UseBasicParsing

# Salida final resumida para documentación
Write-Output ("InstanceId=" + $InstanceId)
Write-Output ("PublicIp="   + $PublicIp)
Write-Output ("HttpStatus=" + $response.StatusCode)
