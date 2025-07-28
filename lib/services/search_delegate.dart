import 'package:flutter/material.dart';

class Service {
  final String title;
  final Widget page;
  final IconData icon;

  Service({required this.title, required this.page, required this.icon});
}

class CustomSearchDelegate extends SearchDelegate {
  final List<Service> services;

  CustomSearchDelegate({required this.services});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Service> matchQuery = [];
    for (var service in services) {
      if (service.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(service);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          leading: Icon(result.icon),
          title: Text(result.title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => result.page),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Service> matchQuery = [];
    for (var service in services) {
      if (service.title.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(service);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          leading: Icon(result.icon),
          title: Text(result.title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => result.page),
            );
          },
        );
      },
    );
  }
}