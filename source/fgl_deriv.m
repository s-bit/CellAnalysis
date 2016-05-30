function Y = fgl_deriv( a, y, h )
% fgl_deriv
%
%   Computes the fractional derivative of order alpha (a) for the function
%   y sampled on a regular grid with spacing h, using the Grunwald-Letnikov
%   formulation.
%
%   Inputs:
%   a : fractional order
%   y : sampled function
%   h : period of the sampling lattice
%
%   Output:
%   Y : fractional derivative estimate given y
%
%   Note that this implementation is similar to that of Bayat 2007
%   (FileExchange: 13858-fractional-differentiator), and takes the exact
%   same inputs, but uses a vectorized formulation to accelerates the
%   computation in Matlab.
%
%   Copyright (C) 2014, Jonathan Hadida
%   All rights reserved.
%   Contact: jonathan dot hadida [a] dtc.ox.ac.uk
%
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%   met:
%
%      1. Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
%      2. Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in
%         the documentation and/or other materials provided with the
%         distribution.
%
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.

%   The views and conclusions contained in the software and documentation 
%   are those of the authors and should not be interpreted as representing 
%   official policies, either expressed or implied, of the FreeBSD Project.


n  = numel(y);
J  = 0:(n-1);
G1 = gamma( J+1 );
G2 = gamma( a+1-J );
s  = (-1) .^ J;

M  = tril( ones(n) );
R  = toeplitz( y(:)' );
T  = meshgrid( (gamma(a+1)/(h^a)) * s ./ (G1.*G2) );
Y  = reshape(sum( R .* M .* T, 2 ), size(y));

end