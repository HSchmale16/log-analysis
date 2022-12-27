import datetime
import boto3


older_than = (datetime.datetime.now() - datetime.timedelta(weeks=13)).strftime("%s")


