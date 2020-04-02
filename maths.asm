segment .data

dd_radians_to_degrees_ratio dq 57.2957795
dd_degrees_to_radians_ratio dq 0.0174532925


; inline double radians_to_degrees(double a)
%define radians_to_degrees mulsd   xmm0, [dd_radians_to_degrees_ratio]

; inline double degrees_to_radians(double a)
%define degrees_to_radians mulsd  xmm0, degrees_to_radians_ratio


