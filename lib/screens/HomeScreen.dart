import 'package:billetera/screens/loan_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billetera/models/user_model.dart';
import 'package:billetera/models/transaction_model.dart';
import 'package:billetera/services/user_service.dart';
import 'package:billetera/services/transaction_service.dart';
import 'package:billetera/screens/profile_screen.dart';
import 'package:billetera/screens/interest_calculation_screen.dart';
import 'package:billetera/constants/app_colors.dart';
import 'package:billetera/constants/app_styles.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  UserModel? _user;
  final UserService _userService = UserService();
  final TransactionService _transactionService = TransactionService();
  List<TransactionModel> _recentTransactions = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Registrar el observer para detectar cambios en el estado de la app
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
  }

  @override
  void dispose() {
    // Eliminar el observer al destruir el widget
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Actualizar datos cuando la app vuelve a primer plano
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  // Método para refrescar todos los datos
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_loadUserData(), _loadRecentTransactions()]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserData() async {
    try {
      UserModel? user = await _userService.getUserData();
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _loadRecentTransactions() async {
    try {
      List<TransactionModel> transactions = await _transactionService
          .getRecentTransactions(10);
      if (mounted) {
        setState(() {
          _recentTransactions = transactions;
        });
      }
    } catch (e) {
      print('Error al cargar transacciones recientes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryColor,
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
                : _buildCurrentScreen(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentScreen() {
    // Aquí seleccionamos qué pantalla mostrar según el índice actual
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return InterestCalculationScreen();
      case 2:
        return LoanManagementScreen();
      case 3:
        return _user != null ? ProfileScreen(user: _user!) : Container();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    if (_user == null) {
      return Center(child: Text('No se pudieron cargar los datos del usuario'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics:
            AlwaysScrollableScrollPhysics(), // Importante para que funcione el RefreshIndicator
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildBalanceCard(),
            _buildQuickActions(),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  _user!.nombres.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola,', style: AppStyles.subheadingSmall),
                  Text(
                    _user!.nombres.split(' ')[0],
                    style: AppStyles.headingMedium,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _refreshData,
                tooltip: 'Actualizar',
              ),
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, Color(0xFF3A1C6C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disponible',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            '\$${NumberFormat('#,###,###').format(_user!.saldo)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Total: \$${NumberFormat('#,###,###.00').format(_user!.saldo)}',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Tu plata',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tus favoritos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _buildQuickActionItem(
                'Interés\nSimple',
                Icons.trending_up,
                Colors.pink[100]!,
              ),
              _buildQuickActionItem(
                'Interés\nCompuesto',
                Icons.show_chart,
                Colors.purple[100]!,
              ),
              _buildQuickActionItem(
                'Anualidades',
                Icons.calendar_today,
                Colors.blue[100]!,
              ),
              _buildQuickActionItem(
                'Préstamos',
                Icons.account_balance,
                Colors.green[100]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(String label, IconData iconData, Color bgColor) {
    return Container(
      width: 90,
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: AppColors.primaryColor),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas transacciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _loadRecentTransactions,
                child: Text(
                  'Actualizar',
                  style: TextStyle(color: AppColors.accentColor),
                ),
              ),
            ],
          ),
        ),
        _recentTransactions.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay transacciones recientes',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              itemBuilder: (context, index) {
                return _buildTransactionItem(_recentTransactions[index]);
              },
            ),
      ],
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    IconData iconData;
    Color iconColor;

    // Definir icono y color según el tipo de transacción
    switch (transaction.type) {
      case 'pago':
        iconData = Icons.arrow_upward;
        iconColor = Colors.green;
        break;
      case 'préstamo':
        iconData = Icons.arrow_downward;
        iconColor = Colors.red;
        break;
      case 'interés':
        iconData = Icons.percent;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.swap_horiz;
        iconColor = Colors.blue;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM, yyyy · HH:mm').format(transaction.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.amount > 0 ? '+' : ''}\$${NumberFormat('#,###').format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.amount > 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Si el usuario vuelve a la pantalla de inicio, actualizamos los datos
          if (index == 0 && _currentIndex != 0) {
            _refreshData();
          }
          // Actualizamos el índice actual
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.accentColor,
        unselectedItemColor: AppColors.textSecondaryColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Cálculos',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Préstamos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
