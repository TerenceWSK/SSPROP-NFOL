% This function solves the coupled-mode nonlinear Schrodinger equations for
% pulse propagation in an optical fiber using the split-step
% Fourier method.
% 
% The following effects are included in the model: group velocity
% dispersion (GVD), higher order dispersion, polarization
% dependent loss, arbitrary fiber birefringence, and
% self-phase modulation. 
%
% USAGE
%
% [u1x,u1y] = sspropvc(u0x,u0y,dt,dz,nz,alphaa,alphab,betapa,betapb,gamma);
% [u1x,u1y] = sspropvc(u0x,u0y,dt,dz,nz,alphaa,alphab,betapa,betapb,gamma,psp);
% [u1x,u1y] = sspropvc(u0x,u0y,dt,dz,nz,alphaa,alphab,betapa,betapb,gamma,psp,method);
% [u1x,u1y] = sspropvc(u0x,u0y,dt,dz,nz,alphaa,alphab,betapa,betapb,gamma,psp,method,maxiter;
% [u1x,u1y] = sspropvc(u0x,u0y,dt,dz,nz,alphaa,alphab,betapa,betapb,gamma,psp,method,maxiter,tol);
%
%
% INPUT
%
% u0x, u0y        Starting field amplitude components
% dt              Time step
% dz              Propagation step size
% nz              Number of steps to take (i.e. L = dz*nz)
% alphaa, alphab  Power loss coefficients for the two eigenstates
%                   (see note (2) below)
% betapa, betapb  Dispersion polynomial coefs, [beta_0 ... beta_m] 
%                   for the two eigenstates (see note (3) below)
% gamma           Nonlinearity coefficient
% psp             Polarization eigenstate (PSP) of fiber, see (4)
% method          Which method to use, either ’circular’ or ’elliptical’ 
%                   (default = ’elliptical’, see instructions)
% maxiter         Max number of iterations per step (default = 4)
% tol             Convergence tolerance (default = 1e-5)
%
%
% OUTPUT
%
% u1x, u1y        Output field amplitudes
%
%
% NOTES
%
% (1) The dimensions of the input and output quantities can
% be anything, as long as they are self consistent.  E.g., if 
% |u|^2 has dimensions of Watts and dz has dimensions of
% meters, then gamma should be specified in W^-1*m^-1.
% Similarly, if dt is given in picoseconds, and dz is given in
% meters, then beta(n) should have dimensions of ps^(n-1)/m.
%
% (2) The loss coefficients (alpha) may optionally be specified
% as a vector of the same length as u0, in which case it is
% treated as vector that describes alpha(w) in the frequency
% domain. (The function wspace.m in the tools subdirectory can
% be used to construct a vector with the corresponding
% angular frequencies.) 
%
% (3) The propagation constant beta(w) can also be specified
% directly by replacing the polynomial argument betap with a
% vector of the same length as u0. In this case, the argument
% betap is treated as a vector describing propagation in the
% frequency domain. 
%
% (4) psp describes the polarization eigenstates of the fiber. If
% psp is a scalar, it gives the orientation of the linear
% birefringence axes relative to the x-y axes.  If psp is a
% vector of length 2, i.e., psp = [psi,chi], it describes the
% describes the ellipse orientation and ellipticity of the
% first polarization eigenstate.  Specifically, (2*psi,2*chi)
% are the% longitude and lattitude of the principal eigenstate
% on the Poincare sphere.  
%
% OPTIONS
%
% Several internal options of the routine can be controlled by 
% separately invoking sspropc with a single argument:
%
% sspropvc -savewisdom      (save accumualted wisdom to file)
% sspropvc -forgetwisdom    (forget accumualted wisdom)
% sspropvc -loadwisdom      (load wisdom from file)
%
% The wisdom file (if it exists) is automatically loaded the
% first time sspropc is executed.
%
% The following four commands can be used to designate the planner
% method used by the FFTW routines in subsequent calls to
% sspropc.  The default method is patient.  These settings are
% reset when the function is cleared or when Matlab is
% restarted. 
%
% sspropc -estimate
% sspropc -measure
% sspropc -patient
% sspropc -exhaustive
%
% See also:  sspropv (equivalent matlab code)
%
% VERSION:  3.0.1
% AUTHORS:  Afrouz Azari (afrouz@umd.edu)
%           Ross A. Pleban (rapleban@ncsu.edu)
%           Reza Salem (rsalem@umd.edu)
%           Thomas E. Murphy (tem@umd.edu)
%
% THIS FILE CONTAINS NO MATLAB CODE, IT ONLY PROVIDES
% DOCUMENTATION FOR THE CORRESPONDING MEX FILE, sspropvc.c  
% PLEASE CONSULT sspropv.m FOR A MATLAB SCRIPT WHICH PERFORMS
% THE SAME FUNCTIONS AS THIS COMPILED MEX PROGRAM.
% 
% AUTHORS:  Afrouz Azari (afrouz@umd.edu)
%           Ross A. Pleban (rapleban@ncsu.edu)
%           Reza Salem (rsalem@umd.edu)
%           Thomas E. Murphy (tem@umd.edu)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2006, Thomas E. Murphy
%
%   This file is part of SSPROP.
%
%   SSPROP is free software; you can redistribute it and/or
%   modify it under the terms of the GNU General Public License
%   as published by the Free Software Foundation; either version
%   2 of the License, or (at your option) any later version.
%
%   SSPROP is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public
%   License along with SSPROP; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%   02111-1307 USA
