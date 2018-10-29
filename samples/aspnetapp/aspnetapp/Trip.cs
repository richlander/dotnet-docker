using System;
using System.Collections.Generic;

public class Trip
{
    public static IEnumerable<string> GetCities()
    {
        var cities = new List<string>()
        {
            "Bangalore",
            "Mumbai",
            "Pune",
            "Delhi"
        };
        return cities;
    }
}