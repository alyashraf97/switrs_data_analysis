import psycopg2
import pandas as pd
import numpy as np

# Database connection parameters
db_params = {
    'dbname': 'switrs',
    'user': 'postgres',
    'password': 'postgres',
    'host': 'localhost'
}

# Establish the database connection
conn = psycopg2.connect(**db_params)

# Define the query to select relevant numerical columns for correlation
query = "SELECT column1, column2, column3 FROM public.collisions;"

# Initialize an empty DataFrame to store the cumulative correlation matrix
cumulative_corr_matrix = pd.DataFrame()

# Use a server-side cursor to stream the results
with conn.cursor(name='streaming_cursor') as cursor:
    cursor.itersize = 10000  # Adjust this based on your memory constraints
    cursor.execute(query)

    # Process the query result in chunks
    for chunk_df in pd.read_sql_query(query, conn, chunksize=cursor.itersize):
        # Convert all columns to numeric, ignoring non-numeric columns
        chunk_df = chunk_df.apply(pd.to_numeric, errors='coerce')

        # Calculate the correlation matrix for the chunk
        chunk_corr_matrix = chunk_df.corr()

        # Combine the chunk's correlation matrix with the cumulative one
        if cumulative_corr_matrix.empty:
            cumulative_corr_matrix = chunk_corr_matrix
        else:
            cumulative_corr_matrix += chunk_corr_matrix

        # Optional: Free up memory if needed
        del chunk_df

# Average the cumulative correlation matrix by the number of chunks processed
cumulative_corr_matrix /= (conn.cursor().rowcount / cursor.itersize)

# Close the database connection
conn.close()

# Now, insert the cumulative correlation matrix into the database
# Re-establish the database connection
conn = psycopg2.connect(**db_params)

# Create a table for the correlation matrix
with conn.cursor() as cursor:
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS public.correlation_matrix (
            variable1 VARCHAR(255),
            variable2 VARCHAR(255),
            correlation NUMERIC
        );
    """)
    conn.commit()

    # Insert the correlation values into the table
    for i in cumulative_corr_matrix.columns:
        for j in cumulative_corr_matrix.index:
            cursor.execute(
                "INSERT INTO public.correlation_matrix (variable1, variable2, correlation) VALUES (%s, %s, %s)",
                (i, j, cumulative_corr_matrix.loc[j, i])
            )
    conn.commit()

# Close the database connection
conn.close()
