{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": ${expire}
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep only recent tagged images",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["v", "latest", "release-", "prod-"],
        "countType": "imageCountMoreThan",
        "countNumber": ${keep}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}