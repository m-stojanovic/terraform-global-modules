{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Retain untagged images only for one day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": ${count_days}
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Retain the last ${count_number} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${count_number}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
