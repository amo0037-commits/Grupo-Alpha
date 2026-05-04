import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerProfilePage extends StatelessWidget {
  const WorkerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
            Color(0xFF64B5F6),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Panel de trabajador",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),

       body: Center(
  child: SingleChildScrollView(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        children: [

          const SizedBox(height: 30),

          
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF64B5F6),
                  child: Text(
                    user?.email != null
                        ? user!.email![0].toUpperCase()
                        : "W",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  user?.email ?? "Worker",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Trabajador activo",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          
          Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _WorkerButton(
                  icon: Icons.access_time,
                  title: "Fichar entrada / salida",
                  color: const Color(0xFF64B5F6),
                  onTap: () {},
                ),
              ),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _WorkerButton(
                  icon: Icons.calendar_month,
                  title: "Mis horarios",
                  color: Colors.white24,
                  onTap: () {},
                ),
              ),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _WorkerButton(
                  icon: Icons.work_outline,
                  title: "Mis tareas",
                  color: Colors.white24,
                  onTap: () {},
                ),
              ),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _WorkerButton(
                  icon: Icons.history,
                  title: "Historial de fichajes",
                  color: Colors.white24,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    ),
  ),
),
      ),
    );
  }
}

class _WorkerButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _WorkerButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_WorkerButton> createState() => _WorkerButtonState();
}

class _WorkerButtonState extends State<_WorkerButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: pressed ? 0.96 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: pressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color),
              const SizedBox(width: 15),
              Text(
                widget.title,
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white24, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}