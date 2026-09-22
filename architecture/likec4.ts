import { defineModel } from '@likec4/core'

export const model = defineModel(({ el, person, system, container }) => {
  const learner = person('Learner', 'Cloud architecture learner')

  // ===== Scenario 1: Static Website =====
  const scenario1 = system('01-static-website', 'Static Website Hosting', {
    description: 'Host static websites on S3 with CDN',
    technology: 'AWS S3, CloudFront',
    tags: ['scenario-1', 'storage', 's3', 'cdn'],
  })

  container('S3 Bucket', 'Static website hosting', {
    parent: scenario1,
    technology: 'AWS S3',
    tags: ['storage'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/01-static-website/terraform/main.tf' },
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/01-static-website/README.md' },
      { title: 'Local Setup', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/01-static-website/local-setup.sh' }
    ]
  })

  // ===== Scenario 2: Serverless API =====
  const scenario2 = system('02-serverless-api', 'Serverless API', {
    description: 'Lambda + API Gateway for REST API',
    technology: 'AWS Lambda, API Gateway',
    tags: ['scenario-2', 'compute', 'serverless', 'api'],
  })

  container('API Gateway', 'HTTP API endpoint', {
    parent: scenario2,
    technology: 'AWS API Gateway',
    tags: ['api'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/02-serverless-api/terraform/main.tf' },
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/02-serverless-api/README.md' }
    ]
  })

  container('Lambda Function', 'Business logic', {
    parent: scenario2,
    technology: 'AWS Lambda',
    tags: ['compute'],
    links: [
      { title: 'Handler', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/02-serverless-api/lambda/' },
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/02-serverless-api/terraform/main.tf' }
    ]
  })

  // ===== Scenario 3: Event-Driven =====
  const scenario3 = system('03-event-driven', 'Event-Driven Architecture', {
    description: 'S3 → SNS → Lambda event processing',
    technology: 'AWS S3, SNS, Lambda',
    tags: ['scenario-3', 'messaging', 'pubsub', 'serverless'],
  })

  container('S3 Bucket', 'File upload source', {
    parent: scenario3,
    technology: 'AWS S3',
    tags: ['storage'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/03-event-driven/terraform/main.tf' }
    ]
  })

  container('SNS Topic', 'Event pub/sub', {
    parent: scenario3,
    technology: 'AWS SNS',
    tags: ['messaging'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/03-event-driven/terraform/main.tf' }
    ]
  })

  container('Lambda Function', 'Event processor', {
    parent: scenario3,
    technology: 'AWS Lambda',
    tags: ['compute'],
    links: [
      { title: 'Handler', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/03-event-driven/lambda/' }
    ]
  })

  // ===== Scenario 4: CRUD API =====
  const scenario4 = system('04-crud-api', 'Database + CRUD API', {
    description: 'DynamoDB + Lambda + API Gateway',
    technology: 'AWS DynamoDB, Lambda, API Gateway',
    tags: ['scenario-4', 'database', 'crud', 'serverless'],
  })

  container('DynamoDB', 'NoSQL database', {
    parent: scenario4,
    technology: 'AWS DynamoDB',
    tags: ['database'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/04-crud-api/terraform/main.tf' }
    ]
  })

  container('Lambda Function', 'API handlers', {
    parent: scenario4,
    technology: 'AWS Lambda',
    tags: ['compute'],
    links: [
      { title: 'Handler', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/04-crud-api/lambda/' }
    ]
  })

  // ===== Scenario 5: 3-Tier Web =====
  const scenario5 = system('05-3tier-web', '3-Tier Web App', {
    description: 'VPC + ALB + EC2 + RDS',
    technology: 'AWS VPC, ALB, EC2, RDS',
    tags: ['scenario-5', 'web', 'database', 'compute', 'enterprise'],
  })

  container('Load Balancer', 'Traffic distribution', {
    parent: scenario5,
    technology: 'AWS ALB',
    tags: ['networking'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/05-3tier-web/terraform/main.tf' }
    ]
  })

  container('EC2 Instances', 'Application servers', {
    parent: scenario5,
    technology: 'AWS EC2',
    tags: ['compute'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/05-3tier-web/terraform/main.tf' }
    ]
  })

  container('RDS Database', 'Relational database', {
    parent: scenario5,
    technology: 'AWS RDS',
    tags: ['database'],
    links: [
      { title: 'Terraform', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/05-3tier-web/terraform/main.tf' }
    ]
  })

  // ===== Scenario 6: CI/CD Pipeline =====
  const scenario6 = system('06-cicd-pipeline', 'CI/CD Pipeline', {
    description: 'GitHub Actions → CodeBuild → CodeDeploy',
    technology: 'GitHub Actions, AWS CodeBuild, CodeDeploy',
    tags: ['scenario-6', 'cicd', 'devops', 'automation'],
  })

  container('GitHub Actions', 'CI/CD orchestration', {
    parent: scenario6,
    technology: 'GitHub Actions',
    tags: ['cicd'],
    links: [
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/06-cicd-pipeline/README.md' }
    ]
  })

  // ===== Scenario 7: Monitoring =====
  const scenario7 = system('07-monitoring', 'Monitoring & Observability', {
    description: 'CloudWatch + Alarms + Dashboards',
    technology: 'AWS CloudWatch, SNS',
    tags: ['scenario-7', 'monitoring', 'observability', 'alerts'],
  })

  container('CloudWatch', 'Metrics & logs', {
    parent: scenario7,
    technology: 'AWS CloudWatch',
    tags: ['monitoring'],
    links: [
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/07-monitoring/README.md' }
    ]
  })

  // ===== Scenario 8: Streaming =====
  const scenario8 = system('08-streaming', 'Real-Time Data Streaming', {
    description: 'Kinesis → Lambda → DynamoDB',
    technology: 'AWS Kinesis, Lambda, DynamoDB',
    tags: ['scenario-8', 'streaming', 'realtime', 'bigdata'],
  })

  container('Kinesis Stream', 'Real-time data ingestion', {
    parent: scenario8,
    technology: 'AWS Kinesis',
    tags: ['streaming'],
    links: [
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/08-streaming/README.md' }
    ]
  })

  // ===== Scenario 9: Microservices =====
  const scenario9 = system('09-microservices', 'Microservices Architecture', {
    description: 'ECS + Service Discovery + Load Balancing',
    technology: 'AWS ECS, Kubernetes',
    tags: ['scenario-9', 'microservices', 'containers', 'orchestration'],
  })

  container('ECS Cluster', 'Container orchestration', {
    parent: scenario9,
    technology: 'AWS ECS / Kubernetes',
    tags: ['orchestration'],
    links: [
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/09-microservices/README.md' }
    ]
  })

  // ===== Scenario 10: Disaster Recovery =====
  const scenario10 = system('10-disaster-recovery', 'Multi-Region DR', {
    description: 'Active-Active failover & backup strategy',
    technology: 'AWS Multi-Region, RTO/RPO',
    tags: ['scenario-10', 'disaster-recovery', 'resilience', 'multiregion'],
  })

  container('Primary Region', 'Active workload', {
    parent: scenario10,
    technology: 'AWS Region',
    tags: ['compute'],
    links: [
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/10-disaster-recovery/README.md' }
    ]
  })

  container('Secondary Region', 'Standby/failover', {
    parent: scenario10,
    technology: 'AWS Region',
    tags: ['compute'],
    links: [
      { title: 'README', url: 'https://github.com/baseline0/cloud-patterns/blob/main/scenarios/10-disaster-recovery/README.md' }
    ]
  })

  // Relationships
  learner -> scenario1
  learner -> scenario2
  learner -> scenario3
  learner -> scenario4
  learner -> scenario5
  learner -> scenario6
  learner -> scenario7
  learner -> scenario8
  learner -> scenario9
  learner -> scenario10
})
