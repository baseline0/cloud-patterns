"""Event-Driven Architecture: S3 → SNS → Lambda

This Lambda function processes S3 events published via SNS.
Demonstrates: event-driven patterns, SNS subscriptions, async processing."""

import json
import logging
from typing import Any, Dict
from urllib.parse import unquote_plus

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Process SNS messages containing S3 event notifications.

    SNS wraps S3 events in this structure:
    {
      "Records": [{
        "Sns": {
          "Message": "{ \"Records\": [{ \"s3\": { \"bucket\": { \"name\": \"...\" }, ... } }] }"
        }
      }]
    }
    """
    logger.info(f"Processing {len(event.get('Records', []))} SNS records")

    processed_count = 0
    error_count = 0

    try:
        for record in event.get("Records", []):
            try:
                process_sns_message(record)
                processed_count += 1
            except Exception as e:
                logger.error(f"Error processing record: {str(e)}", exc_info=True)
                error_count += 1

        result = {
            "statusCode": 200,
            "processed": processed_count,
            "errors": error_count
        }
        logger.info(f"Processing complete: {processed_count} processed, {error_count} errors")
        return result

    except Exception as e:
        logger.error(f"Critical error: {str(e)}", exc_info=True)
        # Return 200 to prevent SNS retry loop
        return {"statusCode": 200, "error": str(e)}


def process_sns_message(record: Dict[str, Any]) -> None:
    """Extract S3 event from SNS message and process."""
    sns = record.get("Sns", {})
    message = sns.get("Message", "{}")

    try:
        s3_event = json.loads(message)
    except json.JSONDecodeError as e:
        logger.warning(f"Invalid JSON in SNS message: {str(e)}")
        return

    for s3_record in s3_event.get("Records", []):
        process_s3_event(s3_record)


def process_s3_event(s3_record: Dict[str, Any]) -> None:
    """Process individual S3 event."""
    s3_data = s3_record.get("s3", {})
    bucket = s3_data.get("bucket", {}).get("name", "unknown")
    key = s3_data.get("object", {}).get("key", "unknown")
    event_name = s3_record.get("eventName", "unknown")

    # Decode URL-encoded key
    key = unquote_plus(key)

    logger.info(f"Event: {event_name} | Bucket: {bucket} | Key: {key}")

    # Determine file type and process
    extension = key.split(".")[-1].lower() if "." in key else "unknown"

    if extension in ["jpg", "jpeg", "png", "gif"]:
        logger.info(f"[IMAGE] Processing: {key}")
        logger.info("  → Would resize image, generate thumbnail")

    elif extension in ["csv", "json", "xml"]:
        logger.info(f"[DATA] Processing: {key}")
        logger.info("  → Would parse data, validate schema, load to DB")

    else:
        logger.info(f"[FILE] Processing: {key}")
        logger.info("  → Generic file processing")

    logger.info(f"✓ Processed: {key}")
