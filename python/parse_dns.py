#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK

import logging
import argparse
import argcomplete
import yaml

from custom_logger import CustomLogger

logger = CustomLogger(name='DNSParser', log_file='dns_parser.log', log_level=logging.INFO).get_logger()

# Function to parse the DNS records from the zone file text
def parse_zone_file(zone_file_path):
    dns_records = []
    zone = "trahan.dev"  # Assuming zone is fixed

    try:
        # Read the zone file content
        with open(zone_file_path, 'r') as file:
            zone_file_content = file.read()

        # Split the content into lines and process each
        for line in zone_file_content.strip().splitlines():
            parts = line.split()

            # Only process lines with enough parts for DNS records
            if len(parts) >= 4:
                host = parts[0]
                record_type = parts[2]
                record_value = parts[3]

                # Skip if it's not A or CNAME
                if record_type in ("A", "CNAME"):
                    dns_records.append({
                        "host": host,
                        "type": record_type,
                        "zone": zone,
                        "record_value": record_value
                    })
        logger.info(f"Successfully parsed {len(dns_records)} records.")
    except Exception as e:
        logger.error(f"Error reading zone file: {e}")
        raise

    return dns_records

# Function to save DNS records to a YAML file
def save_to_yaml(data, output_file):
    try:
        with open(output_file, 'w') as file:
            yaml.dump({"dns_records": data}, file, default_flow_style=False)
        logger.info(f"Data successfully saved to {output_file}")
    except Exception as e:
        logger.error(f"Error saving to YAML: {e}")
        raise

if __name__ == "__main__":
    # Argument parser setup
    parser = argparse.ArgumentParser(description="Parse BIND zone file to YAML format")
    parser.add_argument("--zone-file", required=True, help="Path to the BIND zone file")
    parser.add_argument("--output-file", required=True, help="Path to save the output YAML file")
    argcomplete.autocomplete(parser)
    args = parser.parse_args()

    # Parse the zone file
    records = parse_zone_file(args.zone_file)

    # Save to vars.yaml format
    save_to_yaml(records, args.output_file)

    logger.info(f"Completed parsing and saved {len(records)} records to {args.output_file}")
