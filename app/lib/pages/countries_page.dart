import 'package:flutter/material.dart';
import '../pages/cities_page.dart';
import '../services/countries_api.dart';

class CountriesPage extends StatelessWidget {
  const CountriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
    );
  }
}

_appBar() {
  return AppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 100,
    title: Image.network(
        'https://uploads-ssl.webflow.com/624d97d169834812ce1b1e84/628b8d990919977fc8ec099b_Logo%20Assinatura.png'),
  );
}

_body(context) {
  Future countries = Data.getCountries();
  return FutureBuilder(
    future: countries,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        List countries = snapshot.data;
        return ListView.builder(
          itemCount: countries.length,
          itemBuilder: (BuildContext context, int index) {
            return _listCountries(context, countries[index]);
          },
        );
      }
    },
  );
}

_listCountries(context, String country) {
  return Container(
    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
    ),
    child: ListTile(
      title: Text(country, style: const TextStyle(fontSize: 20)),
      trailing: const Icon(Icons.arrow_circle_right_outlined),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => CitiesPage(country: country)),
        );
      },
    ),
  );
}
