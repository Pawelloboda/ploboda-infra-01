# ploboda-infra-01

Musiałem dodać dwa subnety do aws_db_subnet_group bo : <br>
 DB Subnet Group doesn't meet availability zone coverage requirement. Please add subnets to cover at least 2 availability zones. Current coverage: 1
<br>
Można by dodać jednego hosta ec2 dla każdej z pod sieci, który to byłby takim bastionem do logowania się po ssh z konkretnych ipków firmowych po kluczu ssh.
