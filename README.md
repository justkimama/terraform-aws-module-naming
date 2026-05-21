# terraform-aws-module-naming

実務で使用していた AWS リソースの命名規則を Terraform モジュールとして切り出したものです。
`naming` モジュールで生成した名前を各リソースモジュールが参照する構成にすることで、プロジェクト全体の命名を一元管理できるようにしています。

## 対応内容

- プロジェクト・環境・リソース種別を組み合わせた命名規則を `naming` モジュールに集約
- 各 AWS サービスをラップしたモジュールを個別に用意し、呼び出し側で命名の詳細を意識しなくて済む構造に整理
- 複数プロジェクトをまたいで再利用できるよう、変数は環境名のみをインプットとするシンプルなインターフェースに統一

## モジュール一覧

| カテゴリ | モジュール |
|----------|-----------|
| ネットワーク | `vpc` / `subnet` / `internet_gateway` / `nat_gateway` / `route_table` / `security_group` |
| コンピューティング | `ecs` / `ecr` |
| データベース | `aurora` / `rds_proxy` |
| ストレージ | `s3` |
| 配信・通信 | `alb` / `cloudfront` / `waf` / `firehose` |
| DNS・証明書 | `route53` / `acm/certificate_dns` |
| セキュリティ・運用 | `iam` / `ses` / `guardduty` / `secrets_manager` / `cloudwatch` |

## 使用技術

- Terraform
- AWS（ap-northeast-1）
