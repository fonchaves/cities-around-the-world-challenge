import 'package:flutter/material.dart';
import '../services/countries_api.dart';

class CitiesPage extends StatelessWidget {
  const CitiesPage({super.key, required this.country});
  final String country;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(country),
    );
  }
}

_appBar(BuildContext context) {
  return AppBar(
    leading: BackButton(
      color: Colors.black,
      onPressed: () => Navigator.of(context).pop(),
    ),
    backgroundColor: Colors.white,
    toolbarHeight: 100,
    title: Image.network(
        'https://uploads-ssl.webflow.com/624d97d169834812ce1b1e84/628b8d990919977fc8ec099b_Logo%20Assinatura.png'),
  );
}

_body(country) {
  Future cities = Data.getCities(country);
  return FutureBuilder(
    future: cities,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        List cities = snapshot.data;
        return ListView.builder(
          itemCount: cities.length,
          itemBuilder: (BuildContext context, int index) {
            return _listCities(context, cities[index]);
          },
        );
      }
    },
  );
}

_listCities(context, Map city) {
  return Container(
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
    ),
    child: ListTile(
      title: Text(city["name"], style: const TextStyle(fontSize: 20)),
      subtitle: Text(city["subCountry"]),
      onTap: () {
        () => {};
      },
    ),
  );
}
