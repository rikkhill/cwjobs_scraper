from bs4 import BeautifulSoup
from requests import get
from requests.exceptions import RequestException
from contextlib import closing
from datetime import date
import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# This should error if it doesn't exist
TERMS = os.environ['SCRAPER_TERMS']
TYPE = os.environ.get('SCRAPER_TYPE', '')
# We want a trailing slash iff the type isn't empty string

# snake_case terms for the ID in the DB
scraper_type = '_'.join(TERMS.split() + [TYPE])

# kebab-case terms for the web scrape
search_terms = '-'.join(TERMS.split())

TYPE += '/' if TYPE != '' else ''
BASE_URL = 'https://www.cwjobs.co.uk/jobs/%s' % TYPE
URL = '%s%s/in-london?radius=5&postedwithin=1' % (BASE_URL, search_terms)


def get_html():
    """Get the page we care about and return as plain text."""
    try:
        with closing(get(URL, stream=True)) as response:
            return response.content

    except RequestException as e:
        logger.error('Request exception: %s' % e)
        return None


def extract_count(raw_html):
    """Extract count from plain text"""
    html = BeautifulSoup(raw_html, 'html.parser')
    count = int(html.select('.page-title > span')[0].text)
    return count


def write_results(value):
    """Write the value to DynamoDB."""
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('scraper_results')

    try:
        response = table.put_item(
            Item={
                "scraper_id":  scraper_type,
                "date": int(date.today().strftime('%s')),
                "value": value
            }
        )
    except Exception as e:
        logger.error("Unable to add item to table: %s" % (e))
        return False

    return True


def handler(event, context):
    """Handle lambda invocation."""
    html = get_html()
    count = extract_count(html)
    write_results(count)

    return True


