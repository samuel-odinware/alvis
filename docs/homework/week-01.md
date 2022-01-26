# Homework Week 1

## Question 1: gcloud version

???+ success "gcloud version"
	Google Cloud SDK 370.0.0
	
	bq 2.0.73
	
	core 2022.01.21
	
	gsutil 5.6


## Question 2: terraform apply

???+ success "terraform apply"
	
	google_bigquery_dataset.dataset: Creating...

	google_storage_bucket.data-lake-bucket: Creating...
	
	google_storage_bucket.data-lake-bucket: Creation complete after 2s
	
	google_bigquery_dataset.dataset: Still creating... [10s elapsed]
	
	google_bigquery_dataset.dataset: Creation complete after 12s


## Question 3: Count records

???+ success "Number of trips on 2021-01-15"

	???+ example "SQL Query"

		```sql
		SELECT
			COUNT(*)
		FROM
			"yellow_taxi_trips" t
		WHERE 
			t."tpep_pickup_datetime"::date = '2021-01-15'
		```

	53024

## Question 4: Largest tip for each day

???+ success "Day with the largest tip in January"

	???+ example "SQL Query"

		```sql
		SELECT
			*
		FROM
			"yellow_taxi_trips" t
		WHERE 
			EXTRACT(MONTH FROM t."tpep_pickup_datetime"::date) = 1
		ORDER BY
			t."tip_amount" DESC
		LIMIT 100;
		```

	2021-01-20

## Question 5: Most popular destination

???+ success "Most Popular Destination"

	???+ example "SQL Query"

		```sql
		SELECT
			t."DOLocationID",
			CONCAT(zdo."Borough", ' - ', zdo."Zone") AS "dropoff_loaction",
			COUNT(t."DOLocationID") AS "dropoffs"
		FROM
			yellow_taxi_trips t JOIN zones zpu
			ON t."PULocationID" = zpu."LocationID"
			JOIN zones zdo
			ON t."DOLocationID" = zdo."LocationID"
		GROUP BY
			t."DOLocationID",
			zdo."Borough",
			zdo."Zone"
		ORDER BY
			dropoffs DESC
		```

	236 "Manhattan - Upper East Side North" 73700

## Question 6: Most expensive route

???+ success "Most Popular Destination"

	???+ example "SQL Query"

		```sql
		SELECT
			CONCAT(zpu."Borough", ' - ', zpu."Zone") AS "pickup_location",
			CONCAT(zdo."Borough", ' - ', zdo."Zone") AS "dropoff_loaction",
			AVG(t."total_amount") AS "avg_total"
		FROM
			yellow_taxi_trips t JOIN zones zpu
			ON t."PULocationID" = zpu."LocationID"
			JOIN zones zdo
			ON t."DOLocationID" = zdo."LocationID"
		GROUP BY
			pickup_location,
			dropoff_loaction
		ORDER BY
			avg_total DESC
		```

	"Manhattan - Alphabet City" "Unknown - " 2292.4
