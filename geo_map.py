import psycopg2
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap

# Database connection parameters
db_params = {
    'dbname': 'switrs',
    'user': 'postgres',
    'password': 'postgres',
    'host': 'localhost'
}

conn = psycopg2.connect(**db_params)

# Create a cursor object
cur = conn.cursor()

# Execute the query to get latitude and longitude data
cur.execute("SELECT latitude, longitude FROM collision_locations_mv")

# Fetch all the results
locations = cur.fetchall()

# Close the cursor and connection
cur.close()
conn.close()

# Unpack the latitude and longitude pairs
lats, lons = zip(*locations)

# Set up the basemap with a larger area and adjust the scatter plot settings
fig = plt.figure(figsize=(12, 12))
m = Basemap(projection='merc', llcrnrlat=min(lats), urcrnrlat=max(lats),
            llcrnrlon=min(lons), urcrnrlon=max(lons), lat_ts=20, resolution='i')

m.drawcoastlines()
m.drawcountries()
m.drawstates()
m.fillcontinents(color='lightgray', lake_color='aqua')
m.drawmapboundary(fill_color='aqua')

# Convert latitude and longitude to x and y coordinates
x, y = m(lons, lats)

# Use a hexbin plot for better visualization of density
m.hexbin(x, y, gridsize=100, bins='log', cmap='inferno')

# Add a colorbar to show the scale
plt.colorbar(label='log10(N)')

# Show the plot
plt.show()