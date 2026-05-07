import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../utils/app_assets.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../widgets/custom_profile_info_tile.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  static const String routeName = 'profile_screen';

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            context.read<AuthBloc>().add(UpdateUserData(state.user));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },

        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authState.user;
            return _buildProfileContent(context, user);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(height: 20),

        CircleAvatar(
          radius: 60,
          backgroundImage: user.imageUrl != null && user.imageUrl!.isNotEmpty
              ? NetworkImage(user.imageUrl!)
              : const AssetImage(AppAssets.profile_1) as ImageProvider,
          onBackgroundImageError: (_, __) {},
        ),
        const SizedBox(height: 15),

        Text(
          user.fullName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(user.emailAddress, style: const TextStyle(color: Colors.grey)),

        const SizedBox(height: 10),

        
        ProfileInfoTile(
          icon: Icons.person_outline,
          label: "Full Name",
          value: user.fullName,
        ),

        ProfileInfoTile(
          icon: Icons.email_outlined,
          label: "Email",
          value: user.emailAddress,
        ),

        ProfileInfoTile(
          icon: Icons.phone_outlined,
          label: "Phone",
          value: user.phoneNumber?.isNotEmpty == true
              ? user.phoneNumber!
              : "Not set",
        ),

        ProfileInfoTile(
          icon: Icons.cake_outlined,
          label: "Birth Date",
          value: user.birthDate?.isNotEmpty == true
              ? user.birthDate!
              : "Not set",
        ),

        const Spacer(),

        
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ProfileBloc>(),
                    child: EditProfilePage(user: user),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
