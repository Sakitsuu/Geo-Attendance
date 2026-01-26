import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Geo_Attendant'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App title
                Text(
                  'Geo_Attendant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Location-Based Attendance Management System',
                  style: TextStyle(
                    fontSize: 16,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Geo_Attendant is a location-based attendance management system designed to '
                  'ensure accurate, secure, and transparent workforce attendance tracking. '
                  'The system utilizes real-time geolocation data to authenticate employee '
                  'presence within predefined work zones such as offices, industrial facilities, '
                  'or assigned job sites.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Attendance eligibility is determined by continuously or periodically '
                  'comparing an employee’s live geographic coordinates with authorized geofenced '
                  'areas. Attendance is recorded only when the detected location satisfies the '
                  'spatial constraints of the approved workplace. This mechanism effectively '
                  'mitigates proxy attendance and reduces the risk of location spoofing.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'By integrating geolocation services with automated verification processes, '
                  'Geo_Attendant enhances the accuracy, integrity, and reliability of attendance '
                  'records. The system enables secure, real-time attendance tracking and supports '
                  'efficient workforce management in modern organizational environments.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 32),

                // Features section
                Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                _featureItem(
                  cs,
                  'Real-time geolocation-based attendance verification',
                ),
                _featureItem(
                  cs,
                  'Geofencing for authorized workplace validation',
                ),
                _featureItem(
                  cs,
                  'Prevention of proxy attendance and location spoofing',
                ),
                _featureItem(cs, 'Secure and transparent attendance records'),
                _featureItem(cs, 'Automated and reliable workforce monitoring'),

                const SizedBox(height: 40),

                Center(
                  child: Text(
                    '© Geo_Attendant',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureItem(ColorScheme cs, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.5, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
