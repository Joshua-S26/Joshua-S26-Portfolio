# Put the Olist CSVs here

Download the dataset from Kaggle and unzip the **9 CSV files** directly into this folder:

> https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Expected files:

```
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_order_reviews_dataset.csv
olist_order_payments_dataset.csv
olist_customers_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
olist_geolocation_dataset.csv
product_category_name_translation.csv
```

Then open `../OlistDeliveryInsights.pbip`, set the **CsvFolder** parameter to this folder's full path, and **Refresh**.

The CSVs are git-ignored (see `.gitignore`). The dataset is Olist's; it's downloaded, not redistributed in this repo.
