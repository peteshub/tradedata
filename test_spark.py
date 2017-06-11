import pyspark
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.types import *

spark = SparkSession.builder.master("spark://peter-PC:7077").appName("test").getOrCreate()


customSchema = StructType([ \
    StructField("year", StringType(), True), \
    StructField("make", IntegerType(), True), \
    StructField("model", IntegerType(), True), \
    StructField("comment", StringType(), True), \
    StructField("blank", StringType(), True)])



sqlContext = SQLContext(spark)
df = sqlContext.read.format("com.databricks.spark.csv").option("header","false").option("inferSchema","true").\
    load("/home/peter/PycharmProjects/fetcheddata/BTC_ETH_polo.csv", schema=customSchema)

df.write.parquet("btc_to_eur.parquet")
    


